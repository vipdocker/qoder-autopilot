def get_user():
    wire = {"user_name": "d", "created_at": "x", "email_addr": "e"}  # snake wire fields
    return camelize(wire)


def camelize(d):
    out = {}
    if "user_name" in d:
        out["userName"] = d["user_name"]
    if "created_at" in d:
        out["createdAt"] = d["created_at"]
    # SEEDED DEFECT: email_addr is NOT handled here -> silently dropped from the response
    return out
