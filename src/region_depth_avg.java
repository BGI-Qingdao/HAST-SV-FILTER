import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;

public class region_depth_avg {

	public static void main(String[] args) {
		String cov_file = args[0];
		String ch_id = args[1];
		long start = Long.parseLong(args[2]);
		long end = Long.parseLong(args[3]);
		long start_upstream = Long.parseLong(args[4]);
		long end_downstream = Long.parseLong(args[5]);
		String sv_id = args[6];
		int threshold1 = Integer.parseInt(args[7]);
		int threshold2 = Integer.parseInt(args[8]);
		
		HashMap<String, Integer> cov_rec_hash = new HashMap<String, Integer>();
		read_cov_file(cov_file, cov_rec_hash);
		get_region_cov_avg(ch_id, start, end, start_upstream, end_downstream, sv_id, threshold1, threshold2,  cov_rec_hash);
	}
	
	public static void read_cov_file(String filename, HashMap<String, Integer> cov_rec_hash) {
		try(BufferedReader br = new BufferedReader(new FileReader(filename))){
			String line;
			while((line  = br.readLine()) != null) {
				String[] strs = line.split("\t");
				String pos_id = strs[1];
				int cov = Integer.parseInt(strs[2]);
				cov_rec_hash.put(pos_id, cov);
			}
		}catch(IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void get_region_cov_avg(String ch_id, long start, long end, long start_upstream, long end_downstream, String sv_id, 
			int threshold1, int threshold2, HashMap<String, Integer> cov_rec_hash) {
		
		//tartget_region_average_cov
		float avg = cacl(ch_id, start, end, cov_rec_hash);
		
		//region_upstream_average_cov
		float upstream_avg = cacl(ch_id, start_upstream, start, cov_rec_hash);
		
		//region_downstream_average_cov
		float downstream_avg = cacl(ch_id, end, end_downstream, cov_rec_hash);
		
		if((avg / upstream_avg) < ((float)threshold1 / (float)100) || (avg / downstream_avg) < ((float)threshold1 / (float)100)) {
			System.out.println(ch_id + "\t" + start + "\t" + end + "\t" + sv_id);
		}
		else if((avg / upstream_avg) > ((float)threshold2 / (float)100) && (avg / downstream_avg) > ((float)threshold2 / (float)100)){
			System.out.println(ch_id + "\t" + start + "\t" + end + "\t" + sv_id);
		}
	}
	
	public static float cacl(String id, long start, long end, HashMap<String, Integer> cov_rec_hash) {
		float avg = 0;
		long len = end - start + 1;
		int total = 0;
		for(long i = start ; i <= end ; i++) {
			String key  = "" + i;
			if(cov_rec_hash.containsKey(key)) {
				total += cov_rec_hash.get(key);
			}else {
				System.err.println("cannot find :\tchromosome id : " + id + "\tposition : " + i);
				len--;
			}
		}
		avg = (float)total / (float)len;
		return avg;
	}
	
}
