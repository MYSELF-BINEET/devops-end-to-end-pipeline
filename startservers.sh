# ssh -i mykey ec2-user@$(awk '/\[prod\]/{getline; print $1}' inventory) 'sudo socat TCP4-LISTEN:8080,fork,su=nobody TCP4:192.168.49.2:31933' &

HOST=$(tail -n 1 inventory)

ssh -i "$SSH_KEY" ec2-user@$HOST \
"sudo socat TCP4-LISTEN:8080,fork,su=nobody TCP4:192.168.49.2:31933" &