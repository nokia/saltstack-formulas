include: 
  - java.{{ pillar.get('java', {}).get('flavor', 'openjdk').lower() }}
