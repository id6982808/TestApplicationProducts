// 文字列のインデックスを取得する
public class Chapter03005 {
	public static void main(String[] args) {
		String str = "この𠮷𠮷はサロゲートペアです。";
		// コードポイント単位で先頭から5つ取得する
		for(int i = 0; i < str.offsetByCodePoints(0, 5); i = str.offsetByCodePoints(i, 1)) {
			int codepoint = str.codePointAt(i);
			System.out.printf("%c [u+%h]%n", codepoint, codepoint);
		}
	}
}
