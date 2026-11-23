public void CGLine(float x1, float y1, float x2, float y2) {
    // TODO HW1
    // You need to implement the "line algorithm" in this section.
    // You can use the function line(x1, y1, x2, y2); to verify the correct answer.
    // However, remember to comment out before you submit your homework.
    // Otherwise, you will receive a score of 0 for this part.
    // Utilize the function drawPoint(x, y, color) to apply color to the pixel at
    // coordinates (x, y).
    // For instance: drawPoint(114, 514, color(255, 0, 0)); signifies drawing a red
    // point at (114, 514).

    
     //stroke(0);
     //noFill();
     //line(x1,y1,x2,y2);
    int x1i = round(x1), y1i = round(y1);
    int x2i = round(x2), y2i = round(y2);
    int tmp;

    //太斜就把xy對調變成平緩的線
    boolean steep = abs(y2i - y1i) > abs(x2i - x1i);
    if (steep) {
        tmp = x1i; x1i = y1i; y1i = tmp;
        tmp = x2i; x2i = y2i; y2i = tmp;
    }

    //由右往走的線就把起點、終點對調
    if (x1i > x2i) {
        tmp = x1i; x1i = x2i; x2i = tmp;
        tmp = y1i; y1i = y2i; y2i = tmp;
    }

    //往上走時ystep改為-1
    int dx = x2i - x1i;
    int dy = abs(y2i - y1i);
    int ystep = (y1i < y2i) ? 1 : -1;

    int p = 2 * dy - dx;
    int y = y1i;
    for (int x = x1i; x <= x2i; x++) {
        if (steep) drawPoint(y, x, color(0));
        else drawPoint(x, y, color(0));

        if (p < 0) {
            p += 2 * dy;
        } else {
            y += ystep;
            p += 2 * dy - 2 * dx;
        }
    }
}

public boolean outOfBoundary(float x, float y) {
    if (x < 0 || x >= width || y < 0 || y >= height)
        return true;
    return false;
}

public void drawPoint(float x, float y, color c) {
    int index = (int) y * width + (int) x;
    if (outOfBoundary(x, y))
        return;
    pixels[index] = c;
}

public float distance(Vector3 a, Vector3 b) {
    Vector3 c = a.sub(b);
    return sqrt(Vector3.dot(c, c));
}

boolean pnpoly(float x, float y, Vector3[] vertexes) {
    // TODO HW2 
    // You need to check the coordinate p(x,v) if inside the vertices. 
    // If yes return true, vice versa.

    boolean inside = false;
    int n = vertexes.length;
    // j 永遠是 i 的前一個頂點，所以 (j, i) 剛好走過每一條邊，包括最後一點連回第一點的那條
    for (int i = 0, j = n - 1; i < n; j = i++) {
        Vector3 a = vertexes[i];
        Vector3 b = vertexes[j];
        if (((a.y > y) != (b.y > y)) &&
            (x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x)) {
            inside = !inside;   // 每穿過一次就翻轉
        }
    }
    return inside;
}

public Vector3[] findBoundBox(Vector3[] v) {
    
    
    // TODO HW2 
    // You need to find the bounding box of the vertices v.
    // r1 -------
    //   |   /\  |
    //   |  /  \ |
    //   | /____\|
    //    ------- r2

    // 沒有頂點時（例如圖形整個被裁掉）回傳一個空範圍，避免當掉
    if (v == null || v.length == 0) {
        Vector3[] empty = { new Vector3(0), new Vector3(-1) };
        return empty;
    }

    float minX = v[0].x, minY = v[0].y;
    float maxX = v[0].x, maxY = v[0].y;
    for (int i = 1; i < v.length; i++) {
        minX = min(minX, v[i].x);
        minY = min(minY, v[i].y);
        maxX = max(maxX, v[i].x);
        maxY = max(maxY, v[i].y);
    }

    Vector3 recordminV = new Vector3(minX, minY, 0);
    Vector3 recordmaxV = new Vector3(maxX, maxY, 0);
    Vector3[] result = { recordminV, recordmaxV };
    return result;

}

public Vector3[] Sutherland_Hodgman_algorithm(Vector3[] points, Vector3[] boundary) {
    ArrayList<Vector3> input = new ArrayList<Vector3>();
    ArrayList<Vector3> output = new ArrayList<Vector3>();
    for (int i = 0; i < points.length; i += 1) {
        input.add(points[i]);
    }

    // TODO HW2
    // You need to implement the Sutherland Hodgman Algorithm in this section.
    // The function you pass 2 parameter. One is the vertexes of the shape "points".
    // And the other is the vertices of the "boundary".
    // The output is the vertices of the polygon.

    float orient = signedArea(boundary);   // 裁切框的方向

    for (int k = 0; k < boundary.length; k++) {
        Vector3 A = boundary[k];
        Vector3 B = boundary[(k + 1) % boundary.length];

        output = new ArrayList<Vector3>();
        if (input.size() == 0) break;      // 已經整個被切掉了

        Vector3 S = input.get(input.size() - 1);   // 從最後一點開始，才會處理到「最後一點連回第一點」那條邊
        for (Vector3 E : input) {
            boolean eIn = cross2D(A, B, E) * orient >= 0;
            boolean sIn = cross2D(A, B, S) * orient >= 0;

            if (eIn) {
                if (!sIn) output.add(intersect(A, B, S, E));   // 外 → 內：交點 + E
                output.add(E);                                 // 內 → 內：E
            } else if (sIn) {
                output.add(intersect(A, B, S, E));             // 內 → 外：只有交點
            }                                                  // 外 → 外：不輸出
            S = E;
        }
        input = output;   // 這一輪的輸出就是下一輪的輸入
    }

    Vector3[] result = new Vector3[output.size()];
    for (int i = 0; i < result.length; i += 1) {
        result[i] = output.get(i);
    }
    return result;
}

// 2D 外積：(b - a) x (p - a)
float cross2D(Vector3 a, Vector3 b, Vector3 p) {
    return (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);
}

// 多邊形的有號面積（的兩倍），正負號代表頂點是順時針還是逆時針
float signedArea(Vector3[] poly) {
    float s = 0;
    for (int i = 0; i < poly.length; i++) {
        Vector3 p = poly[i], q = poly[(i + 1) % poly.length];
        s += p.x * q.y - q.x * p.y;
    }
    return s;
}

// S→E 與直線 A→B 的交點
Vector3 intersect(Vector3 a, Vector3 b, Vector3 s, Vector3 e) {
    float cS = cross2D(a, b, s);
    float cE = cross2D(a, b, e);
    float t = cS / (cS - cE);
    return s.add(e.sub(s).mult(t));
}
