// 文字列に含まれる文字を検索する
public class Chapter03002 {
	public static void main(String[] args) {
		String str = "Javaは楽しいですか？Javaマスターになりましょう。";

		System.out.println(str.charAt(5));
		System.out.println(str.indexOf("Java"));
		System.out.println(str.lastIndexOf("Java"));
	}
}
