// 文字列バッファを長さを取得・設定する
public class Chapter03018 {
	public static void main(String[] args) {
		StringBuilder sb = new StringBuilder("Javaは楽しいですか？Javaマスターになりましょう。");

		System.out.println("文字列の長さ："+sb.length());
		sb.setLength(sb.lastIndexOf("Java"));
		System.out.println("文字列の長さ："+sb.codePointCount(0, sb.lastIndexOf("？")));
	}
}
