#!/usr/bin/env sh

# ---
echo "Create Temporary Directory"
TEMP=$(mktemp -d)
cd "${TEMP}" || exit

# ---
echo "Create Dirs in '/repos' volume"
docker exec git-internal-ssh sh -c 'mkdir -p /repos/backend-python/ansible-networking-stage'
docker exec git-internal-ssh sh -c 'mkdir -p /repos/prototypes-and-examples/sandbox-definitions'
docker exec git-internal-ssh sh -c 'mkdir -p /repos/useful-ansible-roles'

# ---
echo "Clone and Copy Sandbox Definitions"
git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/prototypes-and-examples/sandbox-definitions/small-sandbox.git
docker cp small-sandbox.git git-internal-ssh:/repos/prototypes-and-examples/sandbox-definitions

git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/prototypes-and-examples/sandbox-definitions/kypo-crp-demo-training.git
docker cp kypo-crp-demo-training.git git-internal-ssh:/repos/prototypes-and-examples/sandbox-definitions

git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/prototypes-and-examples/sandbox-definitions/kypo-crp-demo-training-adaptive.git
docker cp kypo-crp-demo-training-adaptive.git git-internal-ssh:/repos/prototypes-and-examples/sandbox-definitions


# ---
echo "Clone and Copy Ansible Stage One"
git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/backend-python/ansible-networking-stage/kypo-ansible-stage-one.git
git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/backend-python/ansible-networking-stage/kypo-user-access.git
git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/backend-python/ansible-networking-stage/kypo-interface.git
git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/backend-python/ansible-networking-stage/kypo-common.git
git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/useful-ansible-roles/kypo-disable-qxl.git
#loggings
git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/useful-ansible-roles/kypo-sandbox-logging-forward.git
git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/useful-ansible-roles/kypo-sandbox-logging-msf.git
git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/backend-python/ansible-networking-stage/kypo-man-logging-forward.git
git clone -q --bare https://gitlab.ics.muni.cz/muni-kypo-crp/useful-ansible-roles/kypo-sandbox-logging-bash.git


docker cp kypo-ansible-stage-one.git git-internal-ssh:/repos/backend-python/ansible-networking-stage
docker cp kypo-user-access.git       git-internal-ssh:/repos/backend-python/ansible-networking-stage
docker cp kypo-interface.git         git-internal-ssh:/repos/backend-python/ansible-networking-stage
docker cp kypo-common.git            git-internal-ssh:/repos/backend-python/ansible-networking-stage
docker cp kypo-disable-qxl.git       git-internal-ssh:/repos/useful-ansible-roles/
#loggings
docker cp kypo-sandbox-logging-forward.git git-internal-ssh:/repos/useful-ansible-roles/
docker cp kypo-sandbox-logging-msf.git     git-internal-ssh:/repos/useful-ansible-roles/
docker cp kypo-man-logging-forward.git     git-internal-ssh:/repos/backend-python/ansible-networking-stage/
docker cp kypo-sandbox-logging-bash.git    git-internal-ssh:/repos/useful-ansible-roles/

# ---
echo "Cleanup..."
rm -rf "${TEMP}"

# ---
echo "Done."
