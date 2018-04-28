default: clean
	swipl -q -g start -o flp18-log -c proj2.pl

clean:
	rm -f flp18-log