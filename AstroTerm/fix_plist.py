import plistlib

ids = [
        "cstr6suwn9.skadnetwork","4fzdc2evr5.skadnetwork","2fnua5tdw4.skadnetwork","ydx93a7ass.skadnetwork",
        "p78axxw29g.skadnetwork","v72qych5uu.skadnetwork","ludvb6z3bs.skadnetwork","cp8zw746q7.skadnetwork",
        "3sh42y64q3.skadnetwork","c6k4g5qg8m.skadnetwork","s39g8k73mm.skadnetwork","3qy4746246.skadnetwork",
        "f38h382jlk.skadnetwork","hs6bdukanm.skadnetwork","v4nxqhlyqp.skadnetwork","wzmmz9fp6w.skadnetwork",
        "yclnxrl5pm.skadnetwork","t38b2kh725.skadnetwork","7ug5zh24hu.skadnetwork","mqn14x9xgp.skadnetwork",
        "5tjdwbrq8w.skadnetwork","3rd42ekr43.skadnetwork","9rd848q2bz.skadnetwork","n6fk4nfna4.skadnetwork",
        "kbd757ywx3.skadnetwork","9t245vhmpl.skadnetwork","4468km3ulz.skadnetwork","2u9pt9hc89.skadnetwork",
        "8s468mfl3y.skadnetwork","klf5c3l5u5.skadnetwork","ppxm28t8ap.skadnetwork","uw77j35x4d.skadnetwork",
        "pwa73g5rt2.skadnetwork","578prtvx9j.skadnetwork","4dzt52r2t5.skadnetwork","e5fvkxwrpn.skadnetwork",
        "8c4e2ghe7u.skadnetwork","zq492l623r.skadnetwork","3qcr597p9d.skadnetwork","a2p9lx4jpn.skadnetwork",
        "2267dq36y8.skadnetwork","v9wttpbfk9.skadnetwork","n38lu8286q.skadnetwork","4g2u8y2p5t.skadnetwork",
        "5a6flpkh64.skadnetwork","238da6jt44.skadnetwork","g28c52eehv.skadnetwork","24t9a8vw3c.skadnetwork",
        "252b5q8x7y.skadnetwork","prcb7njmu6.skadnetwork","mlmmfzh3r3.skadnetwork","c3frkrj4fj.skadnetwork",
        "cg4yq2srnc.skadnetwork","x44k69ngh6.skadnetwork","feyaarzu9v.skadnetwork","wg4vff78zm.skadnetwork",
        "mj797d8u6f.skadnetwork","4pfyvq9l8r.skadnetwork","glqzh8vgby.skadnetwork","av6w8kgt66.skadnetwork",
        "x8jpztre38.skadnetwork","k674qkevps.skadnetwork","5lm9lj6jb7.skadnetwork","9nlqeag3gk.skadnetwork",
        "7rz58n8ntl.skadnetwork","294l99pt4k.skadnetwork","gta9lk7p23.skadnetwork","ejvt5qm6ak.skadnetwork",
        "mtkv5xtk9e.skadnetwork","c6k4g5qg8m.skadnetwork","m8dbw4sv7c.skadnetwork","lr83yxwka7.skadnetwork",
        "9b89h5y424.skadnetwork","xy9t38ct57.skadnetwork","tl55sbb4fm.skadnetwork", "3l6bd9hu43.skadnetwork",
        "523jb4fst2.skadnetwork", "737zqs2dbv.skadnetwork", "cj5566h2hx.skadnetwork", "dzg6xy7pwj.skadnetwork",
        "hdw39hrw9y.skadnetwork", "y45688jllp.skadnetwork", "x2vnf7a7k6.skadnetwork", "w9q455wk68.skadnetwork",
        "su67r6k2v3.skadnetwork", "rx5hdcabgc.skadnetwork", "pu4na253f3.skadnetwork", "pwa73g5rt2.skadnetwork"
    ]
ids = list(set(ids))

plist_file = "Info.plist"
with open(plist_file, 'rb') as f:
    pl = plistlib.load(f)

pl["SKAdNetworkItems"] = [{"SKAdNetworkIdentifier": id} for id in ids]
with open(plist_file, 'wb') as f:
    plistlib.dump(pl, f)
print(f"Updated Info.plist with {len(ids)} SKAdNetworkItems!")
