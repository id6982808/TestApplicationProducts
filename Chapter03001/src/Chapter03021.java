// 値を文字列に変換する
public class Chapter03021 {
	public static void main(String[] args) {
		System.out.println(String.valueOf(123));
		System.out.println(String.valueOf(12.3));

		char[] ch = {'あ', 'い', 'う'};
		System.out.println(String.valueOf(ch, 0, ch.length));
	}
}
