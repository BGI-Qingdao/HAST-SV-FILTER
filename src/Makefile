JC=	javac

JAR=	jar

.PHONY: all

all:	extract.jar region_depth_avg.jar chromosome_info_extract.jar

%.class: %.java
	${JC} $<

extract.jar:	extract.class
	${JAR} cfe extract.jar extract extract.class
	
region_depth_avg.jar:	region_depth_avg.class
	${JAR} cfe region_depth_avg.jar region_depth_avg region_depth_avg.class
	
chromosome_info_extract.jar:	chromosome_info_extract.class chromosome_info.class
	${JAR} cfe chromosome_info_extract.jar chromosome_info_extract chromosome_info_extract.class chromosome_info.class

clean:
	rm *.class
