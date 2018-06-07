# Alignement test

curl 'http://sd2.voxolab.com:8000/api/v1.1/transcriptions' -i \
-F auto_file=@align_lcp_gov.xml \
-F ref_file=@align_lcp_gov.txt \
-H 'Authentication-Token: WyIxIiwiYmRlYTlhNmY0MzJmNGY1ODJmNjEzMDYxNWVjMTkzZDYiXQ.C_EV6A.esk1Cwu7T0PpmDKlJ8W82w0eawM'

 curl "http://sd2.voxolab.com:8000/api/v1.1/processes" \
    -X POST \
    -d '{"id":2, "type": "alignment"}' \
    -H 'Content-Type:application/json' \
    -H 'Authentication-Token: WyIxIiwiYmRlYTlhNmY0MzJmNGY1ODJmNjEzMDYxNWVjMTkzZDYiXQ.C_EV6A.esk1Cwu7T0PpmDKlJ8W82w0eawM'


curl "http://sd2.voxolab.com:8000/api/v1.1/download/transcription/2" \
    -H 'Authentication-Token: WyIxIiwiYmRlYTlhNmY0MzJmNGY1ODJmNjEzMDYxNWVjMTkzZDYiXQ.C_EV6A.esk1Cwu7T0PpmDKlJ8W82w0eawM'
