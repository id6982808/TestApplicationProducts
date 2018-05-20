// 文字列バッファを削除する
public class Chapter03023 {
	public static void main(String[] args) {
		StringBuilder sb = new StringBuilder("Java");

		System.out.println(sb.deleteCharAt(3));
		System.out.println(sb.delete(0, 2));
	}
}
