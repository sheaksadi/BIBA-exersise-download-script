# BIBA Exercise Download Script

A bash script to quickly download assignment templates from the OVGU exercise portal.

> Tested with the **Data Structures and Algorithms** course. Should work with other courses on the same portal — just update the `BASE_URL` in the `.env` file.

---

## Requirements

- `curl`
- `unzip`

---

## Setup
```bash
git clone https://github.com/sheaksadi/BIBA-exersise-download-script
cd BIBA-exersise-download-script
chmod +x exse.sh
```

Then edit the `.env` file and fill in your credentials:


```
USER=your.email%40st.ovgu.de
PASSWORD=yourpassword
BASE_URL=https://aud.vc.cs.ovgu.de
```
Check the `env` file for example.  When running add a `.` before `env` and update with your username and password.

## Usage
```bash
./exse.sh <week> <exercise(s)>
```

**Download a single exercise:**
```bash
./exse.sh 1 1
```

**Download multiple exercises at once:**
```bash
./exse.sh 1 1,2,3
```



