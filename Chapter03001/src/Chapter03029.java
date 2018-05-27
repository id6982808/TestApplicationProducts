// 文字列バッファの一部を取得する
public class Chapter03029 {
	public static void main(String[] args)
	{
		StringBuffer sb = new StringBuffer("Hello World!!");

		System.out.println(sb.subSequence(0, 5));
		System.out.println(sb.substring(6));
	}
}
