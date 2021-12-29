CREATE TABLE datetime_dim (
  date_id INTEGER(10) AUTO_INCREMENT PRIMARY KEY,
  date_val DATE NOT NULL,
  hour_val INTEGER(10) NOT NULL,
  weekend BOOLEAN NOT NULL,
  holiday VARCHAR(20),
  
  UNIQUE (date_val, hour_val)
);

CREATE TABLE resource_dim (
  resource_id INTEGER(10) AUTO_INCREMENT PRIMARY KEY,
  resource VARCHAR(200) NOT NULL,
  method VARCHAR(15),
  protocol VARCHAR(200),
  response INTEGER(10) NOT NULL,
  
  UNIQUE (resource, method, protocol, response)
);

CREATE TABLE visitor_dim (
  visitor_id INTEGER(10) AUTO_INCREMENT PRIMARY KEY,
  ip_addr VARCHAR(200) NOT NULL,
  visit_val  INTEGER(10) NOT NULL,
  
  UNIQUE (visit_val)
);

CREATE TABLE resource_fact (
  date_id INTEGER(10),
  resource_id INTEGER(10),
  num_requests INTEGER(10) NOT NULL,
  total_bytes BIGINT(19),
  
  FOREIGN KEY (date_id) REFERENCES datetime_dim(date_id),
  FOREIGN KEY (resource_id) REFERENCES resource_dim(resource_id)
);

CREATE TABLE visitor_fact (
  date_id INTEGER(10),
  visitor_id INTEGER(10),
  num_requests INTEGER(10) NOT NULL,
  total_bytes  INTEGER(10),
  
  FOREIGN KEY (date_id) REFERENCES datetime_dim(date_id),
  FOREIGN KEY (visitor_id) REFERENCES visitor_dim(visitor_id)
);