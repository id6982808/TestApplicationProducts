import java.util.Arrays;
import java.util.List;

// 区切り文字を指定して文字列の連結を行う
public class Chapter03007 {
	public static void main(String[] args) {
		// カンマ区切り文字列にする
		String str1 = String.join(",", "あ","い","う");
		System.out.println(str1);

		// 区切り文字なしの場合
		List<String> list = Arrays.asList("a","b","c");
		String str2 = String.join("", list);
		System.out.println(str2);
	}
}
