// 文字列が指定された接尾辞／接頭辞を持つか調べる
public class Chapter03011 {
	public static void main(String[] args) {
		// 文字列のプロトコルと拡張子を調べる
		String url = "http://localhost/";
		if(url.startsWith("http")) {
			System.out.println("これはHTTPプロトコルです。");
		}
		System.out.println(url.startsWith("local","http://".length()));

		String file = "sample.java";
		if (file.endsWith("java")) {
			System.out.println("これはjavaソースファイルです。");
		}
	}
}
