import java.util.Locale;

// 文字列の大文字／小文字を変換する
public class Chapter03012 {
	public static void main(String[] main) {
		String str = "EnJoY jAvA!!";

		System.out.println(str.toLowerCase());
		System.out.println(str.toUpperCase());
		System.out.println(str.toLowerCase(Locale.getDefault()));
	}
}
