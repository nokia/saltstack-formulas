{% from "postgresql/map.jinja" import jdbc with context -%}
postgresql_jdbc:
  pkg.installed:
    - names:
      - {{ jdbc.postgresql }}
