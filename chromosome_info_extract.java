import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public class chromosome_info_extract {
	
	static ArrayList<chromosome_info> info = new ArrayList<chromosome_info>();

	public static void main(String[] args) {
		
		String headfile = args[0];
		readheadfile(headfile, info);
		write_chr_info(info);
	}
	
	public static void readheadfile(String headfile, ArrayList<chromosome_info> info) {
		try(BufferedReader br = new BufferedReader(new FileReader(headfile))){
			String line;
			while((line = br.readLine()) != null) {
				String[] strs = line.split("\t");
				if(strs[0].equals("@SQ")) {
					String id = strs[1].substring(3);
					int len = Integer.parseInt(strs[2].substring(3));
					chromosome_info ci = new chromosome_info(id, len);
					info.add(ci);
				}
			}
		}catch(IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void write_chr_info(ArrayList<chromosome_info> info) {
		System.out.println("#!/bin/bash");
		System.out.println("declare -A chr_len");
		for(int i = 0 ; i < info.size() ; i++) {
			System.out.println("chr_len" + "[\"" + info.get(i).getId() + "\"]" + "=" + info.get(i).getLen());
		}
	}
}
