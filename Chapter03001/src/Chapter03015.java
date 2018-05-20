// 可変長文字列(文字列バッファ)を作成する
public class Chapter03015 {
	public static void main(String[] args)
	{
		String str = "Javaは難しいですか？";
		StringBuilder sb = new StringBuilder(str);

		System.out.println(sb);
		CharSequence charsequence = str;
		StringBuffer sbf = new StringBuffer(charsequence);
		System.out.println(sbf);
	}
}
