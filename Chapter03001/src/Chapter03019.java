// 文字バッファに含まれる文字コードを取得する
public class Chapter03019 {
	public static void main(String[] args) {
		String str = "この𠮷𠮷はサロゲートペアです";

		StringBuilder sb = new StringBuilder(str);
		StringBuffer sbf = new StringBuffer(str);

		int codepoint = sb.codePointAt(6);
		System.out.printf("%c [u+%h]", codepoint, codepoint);
		Chapter03004.printHex(Character.toChars(codepoint));
		System.out.println();

		codepoint = sbf.codePointBefore(4);
		System.out.printf("%c [u+%h]", codepoint, codepoint);
		Chapter03004.printHex(Character.toChars(codepoint));
		System.out.println();

	}
}
