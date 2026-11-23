// ===== Bonus: SSAA (Super-Sampling Anti-Aliasing) =====
// 每個像素取 SS x SS 個樣本，每個樣本有自己的顏色和深度（不和相鄰像素共用），
// 所有圖形畫完後，再把每個像素的樣本平均（resolve）成最後的顏色。

boolean useSSAA = true;     // 按 A 切換開/關，方便截圖比較
final int SS = 2;           // 每個方向的取樣數 → 2x2
final int SPP = SS * SS;    // 每個像素的樣本數 (samples per pixel)

color[] sampleColor;        // 每個樣本自己的顏色
float[] sampleDepth;        // 每個樣本自己的深度

// 第 k 個子格中心在像素內的偏移量：0.25、0.75
float sampleOffset(int k) {
    return (k + 0.5) / SS;
}

// 每一幀開始時，把所有樣本清成背景色、深度設成無限遠
void clearSamples(color bg) {
    int n = width * height * SPP;
    if (sampleColor == null || sampleColor.length != n) {
        sampleColor = new color[n];
        sampleDepth = new float[n];
    }
    for (int i = 0; i < n; i++) {
        sampleColor[i] = bg;
        sampleDepth[i] = Float.MAX_VALUE;
    }
}

// 寫入像素 (x, y) 的第 s 個樣本，通過深度測試才會寫入
// 用 <=：深度相同時，後畫的圖形蓋過先畫的（和沒開 SSAA 時的行為一致）
void writeSample(int x, int y, int s, float depth, color c) {
    if (outOfBoundary(x, y))
        return;
    int k = (y * width + x) * SPP + s;
    if (depth <= sampleDepth[k]) {
        sampleDepth[k] = depth;
        sampleColor[k] = c;
    }
}

// 把 [x0, x1) x [y0, y1) 範圍內每個像素的樣本取平均，寫回 pixels[]
void resolveSamples(int x0, int y0, int x1, int y1) {
    loadPixels();
    for (int y = y0; y < y1; y++) {
        for (int x = x0; x < x1; x++) {
            if (outOfBoundary(x, y))
                continue;
            int base = (y * width + x) * SPP;
            int r = 0, g = 0, b = 0;
            for (int s = 0; s < SPP; s++) {
                color c = sampleColor[base + s];
                r += (c >> 16) & 0xFF;
                g += (c >> 8) & 0xFF;
                b += c & 0xFF;
            }
            pixels[y * width + x] = color(r / SPP, g / SPP, b / SPP);
        }
    }
    updatePixels();
}
