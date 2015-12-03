select
  s.dcid as schoolstaffdcid,
  xs.schoolstaffdcid as schoolstaffdcid_from_ext,
  s.users_dcid,
  xs.unique_id,
  u.lastfirst,
  u.email_addr
from schoolstaff s
  left outer join users u on s.users_dcid = u.dcid
  left outer join u_def_ext_schoolstaff xs on s.dcid = xs.schoolstaffdcid;