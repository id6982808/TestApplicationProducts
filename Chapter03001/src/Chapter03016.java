// 文字列バッファに文字を設定する
public class Chapter03016 {
	public static void main(String[] args) {
		StringBuilder sb = new StringBuilder("Javaは難しいですか？");
		sb.setCharAt(sb.indexOf("難"),'楽');
		System.out.println(sb);

	}
}
