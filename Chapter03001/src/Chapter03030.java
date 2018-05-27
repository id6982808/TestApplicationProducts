// 絶対値を求める
public class Chapter03030 {
	public static void main(String[] args) {
		for (int i = -1; i < 2 ; i++) {
			System.out.println(i + "の絶対値は" + Math.abs(i) + "です");
		}

		for (double d = -1.0; d < 1.3; d += 1.1) {
			System.out.println(d + "の絶対値は" + Math.abs(d) + "です");
		}
	}
}
