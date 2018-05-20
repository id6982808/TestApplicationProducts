// 文字列に含まれる文字コードを取得する
public class Chapter03004 {

	static void printHex(char[] cs) {
		for(char c : cs) {
			System.out.printf("0x%h ", (int)c);
		}
	}

	public static void main(String[] args) {
		String str = "この𠮷𠮷はサロゲートペアです";

		int codepoint = str.codePointAt(6);
		System.out.printf("%c[u+%h] ", codepoint,codepoint);

		Chapter03004.printHex(Character.toChars(codepoint));
		System.out.println();

		codepoint = str.codePointBefore(4);
		System.out.printf("%c[u+%h] ",codepoint,codepoint);
		Chapter03004.printHex(Character.toChars(codepoint));
		System.out.println();
	}
}
