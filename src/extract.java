import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public class extract {
	
	public static ArrayList<String> svid = new ArrayList<String>();

	public static void main(String[] args) {
		String bedfile = args[0];
		String vcffile = args[1];
		readbedfile(bedfile, svid);
		readvcffile(vcffile, svid);
	}
	
	public static void readbedfile(String bedfile, ArrayList<String> svid) {
		try(BufferedReader br = new BufferedReader(new FileReader(bedfile))){
			String line;
			while((line = br.readLine()) != null) {
				String[] strs = line.split("\t");
				svid.add(strs[3]);
			}
		}catch(IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void readvcffile(String vcffile, ArrayList<String> svid) {
		try(BufferedReader br = new BufferedReader(new FileReader(vcffile))){
			String line;
			while((line = br.readLine()) != null) {
				String[] strs = line.split("");
				if(strs[0].equals("#")) {
					System.out.println(line);
				}else {
					String[] strs1 = line.split("\t");
					for(int i = 0 ; i < svid.size() ; i++) {
						if(svid.get(i).equals(strs1[2])) {
							System.out.print(line + "\n");
						}
					}
				}
			}
		}catch(IOException e) {
			e.printStackTrace();
		}
	}

}





