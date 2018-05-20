// 文字列バッファを検索する
public class Chapter03017 {
	public static void main(String[] args) {
		StringBuilder sb = new StringBuilder("あいうかきくあいう");

		System.out.println(sb.indexOf("う"));
		System.out.println(sb.indexOf("う",5));
		System.out.println(sb.lastIndexOf("う"));
		System.out.println(sb.charAt(sb.lastIndexOf("う")));
	}
}
