// 文字列バッファのインデックスを取得する
public class Chapter03020 {
	public static void main(String[] args)
	{
		String str = "この𠮷𠮷はサロゲートペアです";
		StringBuilder sb = new StringBuilder(str);

		// コードポイント単位で先頭から5つ取得する
		for (int i=0; i < sb.offsetByCodePoints(0, 5); i = sb.offsetByCodePoints(i, 1))
		{
			int codepoint = str.codePointAt(i);
			System.out.printf("%c [u+%h] %n", codepoint, codepoint);
		}


	}
}
