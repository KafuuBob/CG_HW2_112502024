Engine engine;

void setup() {
    size(1000, 600);
    pixelDensity(1); // HiDPI 螢幕下 pixels[] 會變成 2 倍大，drawPoint 的索引會算錯
    engine = new Engine();
}

void draw() {
    background(255);

    engine.run();

}

void keyPressed() {
    if (key == 'a' || key == 'A')
        useSSAA = !useSSAA;   // 切換 SSAA，方便截圖比較
}
