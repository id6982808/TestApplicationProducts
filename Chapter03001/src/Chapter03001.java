// 文字列クラスを生成する
public class Chapter03001 {

	public static void main(String[] args) {
		char ary[] = {'j','a','v','a'};
		String str = new String(ary);

		System.out.println(str);

		String str2 = new String(ary,1,2);
		System.out.println(str2);

	}
}
