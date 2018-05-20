// 文字列の長さを取得する
public class Chapter03003 {
	public static void main(String[] args) {
		String str = "一二三";

		System.out.println(str.length());

		str = "𠮷𠮷";
		System.out.println(str.length());
		System.out.println(str.codePointCount(0, str.length()));
	}
}
