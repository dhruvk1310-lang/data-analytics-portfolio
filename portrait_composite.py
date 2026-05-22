#!/usr/bin/env python3
"""
Split-face portrait compositor.
Combines the right half of a human face with the left half of a pet face
in a vertical 9:16 frame, with gradient blending at the seam.

Usage:
    python portrait_composite.py human.jpg pet.jpg output.jpg
"""

import sys
import cv2
import numpy as np
from PIL import Image, ImageFilter


# ── output dimensions (9:16 portrait) ──────────────────────────────────────
OUT_W, OUT_H = 1080, 1920
BLEND_WIDTH = 60          # pixels each side of center seam for gradient blend


def load_bgr(path: str) -> np.ndarray:
    img = cv2.imread(path)
    if img is None:
        raise FileNotFoundError(f"Cannot read image: {path}")
    return img


def detect_face(img_bgr: np.ndarray) -> tuple[int, int, int, int]:
    """Return (x, y, w, h) of the largest detected face."""
    gray = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
    cascade_path = cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
    detector = cv2.CascadeClassifier(cascade_path)
    faces = detector.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(80, 80))
    if len(faces) == 0:
        # fallback: use the whole image centre
        h, w = img_bgr.shape[:2]
        margin = min(h, w) // 6
        return margin, margin, w - 2 * margin, h - 2 * margin
    # largest face by area
    return max(faces, key=lambda r: r[2] * r[3])


def face_crop_square(img_bgr: np.ndarray, padding: float = 0.35) -> np.ndarray:
    """
    Crop a padded square region around the detected face
    so both eyes and the chin are included with breathing room.
    """
    x, y, w, h = detect_face(img_bgr)
    cx, cy = x + w // 2, y + h // 2
    size = int(max(w, h) * (1 + padding))
    ih, iw = img_bgr.shape[:2]

    x1 = max(0, cx - size // 2)
    y1 = max(0, cy - size // 2)
    x2 = min(iw, x1 + size)
    y2 = min(ih, y1 + size)
    # shift if clipped
    if x2 - x1 < size:
        x1 = max(0, x2 - size)
    if y2 - y1 < size:
        y1 = max(0, y2 - size)
    return img_bgr[y1:y2, x1:x2]


def resize_to_half_canvas(crop: np.ndarray) -> np.ndarray:
    """Resize cropped face to fill one half of the output canvas (OUT_W/2 × OUT_H)."""
    half_w = OUT_W // 2
    return cv2.resize(crop, (half_w, OUT_H), interpolation=cv2.INTER_LANCZOS4)


def build_gradient_mask(width: int, height: int, blend_px: int) -> np.ndarray:
    """
    3-channel float mask [0..1] that is 1 on the left, 0 on the right,
    with a smooth cosine blend across blend_px pixels at the centre seam.
    """
    mask = np.ones((height, width), dtype=np.float32)
    half = width // 2
    start = half - blend_px
    end = half + blend_px
    for col in range(start, end):
        t = (col - start) / (2 * blend_px)
        mask[:, col] = 0.5 * (1 + np.cos(np.pi * t))
    mask[:, end:] = 0.0
    return np.stack([mask, mask, mask], axis=2)


def composite(human_path: str, pet_path: str, out_path: str) -> None:
    print(f"Loading images …")
    human = load_bgr(human_path)
    pet   = load_bgr(pet_path)

    print("Detecting and cropping faces …")
    human_crop = face_crop_square(human, padding=0.30)
    pet_crop   = face_crop_square(pet,   padding=0.30)

    print("Resizing to canvas halves …")
    human_half = resize_to_half_canvas(human_crop)   # left side → human right cheek
    pet_half   = resize_to_half_canvas(pet_crop)     # right side → pet left cheek

    # Mirror human so the face leans toward the centre (right cheek faces right)
    human_half = cv2.flip(human_half, 1)

    print("Compositing with gradient seam blend …")
    canvas = np.zeros((OUT_H, OUT_W, 3), dtype=np.float32)
    left   = human_half.astype(np.float32)
    right  = pet_half.astype(np.float32)
    half_w = OUT_W // 2

    # Place right side first
    canvas[:, half_w:] = right

    # Build left-half mask for the blended seam area
    mask = build_gradient_mask(half_w, OUT_H, BLEND_WIDTH)

    # Blend seam strip for the left half: human * mask + pet-left-strip * (1-mask)
    pet_left_strip = right[:, :half_w]          # leftmost pixels of the right image
    left_blended   = left * mask + pet_left_strip * (1.0 - mask)
    canvas[:, :half_w] = left_blended

    result = np.clip(canvas, 0, 255).astype(np.uint8)

    # Light sharpening pass via Pillow USM
    pil_img = Image.fromarray(cv2.cvtColor(result, cv2.COLOR_BGR2RGB))
    pil_img = pil_img.filter(ImageFilter.UnsharpMask(radius=1.2, percent=60, threshold=3))

    pil_img.save(out_path, quality=97, subsampling=0)
    print(f"Saved → {out_path}  ({OUT_W}×{OUT_H} px)")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python portrait_composite.py <human_photo> <pet_photo> <output>")
        sys.exit(1)
    composite(sys.argv[1], sys.argv[2], sys.argv[3])
