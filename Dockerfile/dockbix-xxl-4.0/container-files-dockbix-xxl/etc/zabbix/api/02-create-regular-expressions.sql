BEGIN;
SET @rid = IFNULL((SELECT MAX(regexpid) AS id FROM regexps),0);
SET @eid = IFNULL((SELECT MAX(expressionid) AS id FROM expressions),0);
INSERT INTO `regexps` (regexpid,name,test_string) VALUES
(@rid+1,'Exclude Docker related file systems','/var/lib/docker/devicemapper/mnt/123456'),
(@rid+2,'Exclude Docker related network interfaces','veth29caba3');
INSERT INTO `expressions`
(expressionid,regexpid,expression,expression_type,exp_delimiter,case_sensitive)
VALUES
(@eid+1,@rid+1,'(/devicemapper/mnt/|/aufs/mnt/)',4,',',1),
(@eid+2,@rid+2,'^veth',4,',',1);
DELETE FROM ids WHERE table_name='regexps' AND field_name='regexpid';
DELETE FROM ids WHERE table_name='expressions' AND field_name='expressionid';
COMMIT;
