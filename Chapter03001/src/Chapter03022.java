// 文字列バッファに追加する
public class Chapter03022 {
	public static void main(String[] args) {
		StringBuilder sb = new StringBuilder("Java");

		System.out.println(sb.append("?"));
		System.out.println(sb.append(123));

		char[] ch = {'あ','い','う'};
		System.out.println(sb.append(ch));
		CharSequence cs = new String("か き く");
		System.out.println(sb.append(cs));
	}
}
