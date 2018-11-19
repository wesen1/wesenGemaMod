Templates
=========

TextTemplates are used to generate single row strings. Leading whitespace, trailing whitespace per line and line endings are removed. <br />
TableTemplates are the same like TextTemplates but use special tags to split the generated string into tables.

Both template types must have the file extension ".template".


Templating
----------

The template engine that is used to render the templates is lua-resty-template. <br/>
Refer to the [lua-resty-template](https://github.com/bungle/lua-resty-template) documentation for templating instructions.


### TableTemplate Tags ###

TableTemplates are split into rows and columns by using these tags:


#### Row separator ####

* At least 2x "_" followed by ";"
* The text will be split into rows at a row separator
* Example: `_____________;`

#### Column separator ####

* At least 2x "-" followed by ";"
* The text inside a row will be split into columns at a column separator
* Example: `-------------;`

#### Field Tag ####

* At least 2x "-" followed by "[FIELD]" or "[ENDFIELD]" and ending with zero or more "_" and ";"
* This will force the contents between the opening and closing field tag into a single row field in the current row
* Example: `------[FIELD]------;`, `------[ENDFIELD]------;`


### Template Including ###

You can include other templates by using the paths relative from the templates base folder to the templates.
The file extension ".template" must be omitted.
