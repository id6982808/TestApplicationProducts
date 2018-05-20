// 文字列を分割する
public class Chapter03009 {
	public static void main(String[] args) {
		String str1 = "にんじん・たまねぎ・じゃがいも";
		String str2 = str1.replaceAll("[^あ-ん]","と");

		String[] strAry = str2.split("と");

		for(String str : strAry) {
			System.out.println(str);
		}
		System.out.println();

		strAry = str2.split("と",2);
		for(String str : strAry) {
		System.out.println(str);
		}
	}
}
