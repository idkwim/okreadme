  OK! Readme
==========

If you want **require** syntax in Markdown, use it. :-)

**OKReadme** change `README.ok.md` file to `README.md`. it's very simple.

## Installation

```sh
$ git clone https://github.com/wan2land/okreadme.git
$ cd okreadme
$ make
$ make install PREFIX=/your/path/bin
```

type `okreadme -v`, the output is as follows:

```
OK Readme 0.1.0
Is Your Readme OK? :-)
```

## How to use

create `README.ok.md` file, then write the flowing. 

```
@code("templates/hello.c")
```

the command is also very easy.

```sh
$ okreadme > README.md
$ okreadme README.ok.md > README.md # default input is README.ok.md
```

**Result**

```c
#include<stdio.h>

int main() {
	// hello world :-)

	printf("Hello World\n");

	return 0;
}
```

## Syntax

### 1. insert entire source.

show [templates/hello.c](templates/hello.c) file.

```
@code("templates/hello.c")
```

**Result**

```c
#include<stdio.h>

int main() {
	// hello world :-)

	printf("Hello World\n");

	return 0;
}
```


### 2. insert part of source by line numbers.

show [templates/hello.c](templates/hello.c) file.

```
@code("templates/hello.c:4-8")
```

**Result**

```c
// hello world :-)

printf("Hello World\n");

return 0;
```

### 3. insert part of source by section name.

show [templates/hello.php](templates/hello.php) file.

```
@code("templates/hello.php@code-by-section-name")
```

**Result**

```php
function codeBySectionName() {
    bar();
}
```


### 4. fix language in syntax highlighting.

use the second parameter. it's very simple.

show [templates/hello.unknown](templates/hello.unknown) file.

```
@code("templates/hello.unknown", "go")
```

**Result**

```go
package main

import "fmt"

func main() {
    fmt.Println("hello world")
}
```

## Tips

### OKREADME with git hooks

install okreadme, then copy the following and paste it into `.git/hooks/pre-commit`.

```sh
#!/bin/sh

if [ -f "README.ok.md" ]; then
	okreadme > README.md
	git add README.md
fi
```

that's all. manage only `README.ok.md`.
