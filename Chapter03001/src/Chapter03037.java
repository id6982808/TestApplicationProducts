// 三角関数を求める
public class Chapter03037 {
	public static void main(String[] args) {
		double a = 90.0;
		double s = Math.sin(Math.toRadians(a));

		double as = Math.toDegrees(Math.asin(s));
		System.out.println(as);
	}
}
