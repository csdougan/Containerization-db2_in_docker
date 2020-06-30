FROM registry.access.redhat.com/rhel7
MAINTAINER Craig Dougan "Craig.Dougan@gmail.com"

ENV db_version v10.5fp7
ENV package_url http://1.2.2.1:32771 
ENV package_name ${db_version}${db_version}_linuxx64_server_t.tar.gz 
ENV licence_file db2ese_o.lic
RUN cd /tmp && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --enable rhel-7-server-extras-rpms && \
    yum-config-manager --enable rhel-7-server-supplementary-rpms && \
    yum install -y wget && \
    yum install -y pam.i686 && \
    yum install -y pam && \
    yum install -y libaio.i686 && \
    yum install -y libaio && \
    yum install -y compat-libstdc++-33 && \
    yum install -y ksh && \
    yum install -y pam-devel.i686 && \
    yum install -y pam-devel && \
    yum install -y file && \
    mkdir -p /opt/IBM/db2 && \
    mkdir -p /db2data/db2fs1p0/abcds1i && \
    mkdir -p /db2data/db2logsp0/abcds1i && \
    mkdir -p /db2data/db2tmp1p0/abcds1i && \
    mkdir -p /db2home/abcds1a && \
    mkdir -p /db2home/abcds1f  && \
    mkdir -p /db2home/abcds1i && \
    mkdir -p /db2home/abcdsds1 && \
    mkdir -p /db2data/hk && \
    mkdir -p /db2data/logs && \
    mkdir -p /db2export && \
    groupadd -g 300 db2iadm && \
    groupadd -g 307 db2ctrl && \
    groupadd -g 306 db2maint && \
    groupadd -g 305 db2mon && \
    groupadd -g 301 db2admg && \
    groupadd -g 302 db2feng && \
    groupadd -g 303 abcds1rw && \
    groupadd -g 304 abcds1ro && \   
    useradd  -d /db2home/abcds1i -u 300 -g db2iadm abcds1i && \
    useradd  -d /db2home/abcds1a -u 301 -g db2admg abcds1a && \
    useradd -d /db2home/abcds1f -u 302 -g db2feng abcds1f  && \
	useradd -d /db2home/abcdsds1 -u 303 -g abcds1rw abcdsds1 && \
	chown -R abcds1i:db2iadm /db2data && \
	chown -R abcds1a:db2admg /db2home/abcds1a && \
	chown -R abcds1f:db2feng /db2home/abcds1f && \
	chown -R abcds1i:db2iadm /db2home/abcds1i && \
	chown -R abcdsds1:abcds1rw /db2home/abcdsds1
	
ADD abcds1i.rsp /db2export/abcds1i.rsp
ADD abcds1i.INS /db2export/abcds1i.INS
	
RUN mkdir /installdir && \
    cd /installdir && \
    wget ${package_url}/${package_name} && \
	tar zxvf ${package_name} && \
	cd server_t && \
	./db2setup -r /db2export/abcds1i.rsp && \
	./db2ls -b /opt/IBM/db2/V10.5_fp7 -q 

ADD create_db.sh /installdir/create_db.sh
ADD ${licence_file} /installdir/${licence_file} 

RUN	cd /installdir && \
	su - abcds1i -c ". ~/sqllib/db2profile;  db2licm -a /installdir/${licence_file}"
RUN 	chown abcds1i:db2iadm /installdir/create_db.sh && \
	chmod 750 /installdir/create_db.sh 

RUN su - abcds1i -c ". ~/sqllib/db2profile; db2start &" 
RUN su - abcds1i -c ". ~/sqllib/db2profile; /installdir/create_db.sh abcds1d"

ENTRYPOINT ["bash"]	
	
    

    
