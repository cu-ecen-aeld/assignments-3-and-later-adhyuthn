src := writer.c
exec := writer

CC := aarch64-none-linux-gnu-gcc

writer: $(src)
	$(info Compiler selected is $(CC))
	$(CC) -o $(exec) $(src)

clean:
	rm -f $(exec)
