// 文字列バッファに挿入する
public class Chapter03024 {
	public static void main(String[] args) {
		StringBuilder sb = new StringBuilder("今年は年です。");

		System.out.println(sb.insert(3, "2018"));
	}
}
