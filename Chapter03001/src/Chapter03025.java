// 文字列バッファを置換する
public class Chapter03025 {
	public static void main(String[] args) {
		StringBuilder sb = new StringBuilder("Javaは楽しい");
		System.out.println(sb.replace(5, 8, "難しい！"));
	}
}
