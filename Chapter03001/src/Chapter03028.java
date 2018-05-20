// 文字列バッファを配列にコピーする
public class Chapter03028 {
	public static void main(String[] args) {
		StringBuilder sb = new StringBuilder("panda");

		char[] dst = {'J','a','v','a','!'};

		sb.getChars(0, 3, dst, 2);

		for(char c : dst) {
			System.out.println(c);
		}
	}
}
