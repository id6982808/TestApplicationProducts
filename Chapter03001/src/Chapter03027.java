// 文字列バッファの容量を操作する
public class Chapter03027 {
	public static void main(String args[]) {
		StringBuilder sb = new StringBuilder("Java");

		System.out.println(sb.capacity());
		sb.ensureCapacity(30);
		System.out.println(sb.capacity());
	}
}
