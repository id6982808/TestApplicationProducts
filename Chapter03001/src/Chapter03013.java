// 文字列を比較する
public class Chapter03013 {
	public static void main(String[] args) {
		String str = "Java!!";
		String strUp = "JAVA!!";
		String strMes = "Do you enjoy Java?";
		StringBuffer strBuf = new StringBuffer("JAVA!");

		if (str.compareToIgnoreCase("C!") > 0) {
			System.out.println("C! > Java!");
		}

		if (str.contentEquals(strBuf)) {
			System.out.println(str + "と" + strBuf + "は等しいです。");
		}

		if (str.equalsIgnoreCase(strUp)) {
			System.out.println(str + "と" + strUp + "は等しいです。");
		}

		String strNum = "0123-456";
		if (strNum.matches("[0-9]{4}-[0-9]{3}")) {
			System.out.println("7桁の郵便番号です。");
		}

		if (str.regionMatches(0, strMes, 13, 4)) {
			System.out.println(str + "の0文字目から4文字と" + strMes + "の13文字目から4文字は等しいです。");
		}

	}
}
