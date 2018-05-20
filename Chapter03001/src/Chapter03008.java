// 文字列の置換を行う
public class Chapter03008 {
	public static void main(String[] args) {
		String str1 = "にんじん・たまねぎ・じゃがいも";
		String str2 = str1.replace("・","と");
		String str3 = str1.replaceAll("[^あ-ん]", "と");
		String str4 = str1.replaceFirst("[^あ-ん]", "と");

		System.out.println(str2);
		System.out.println(str3);
		System.out.println(str4);
	}
}
