#include <assert.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

#include "config_parser.h"
#include "util.h"

static int read_config_file(const char *fname, struct config_item items[],
                            FILE *error);

/**
 * Copy a string and trim of leading and trailing white space characters.
 * Allow the user to escape out the stop character by putting a backslash before
 * the character.
 * @param dest where to store the result
 * @param size size of the result buffer
 * @param src where to copy data from
 * @param end the last character parsed is returned here
 * @param stop the character to stop copying.
 * @return 0 if success, -1 otherwise
 */
static int trim_copy(char *dest, size_t size, const char *src, 
                     const char **end, char stop) {
   while (isspace(*src)) {
      ++src;
   }
   char *space = NULL;
   size_t n = 0;
   bool escape = false;
   int ret = 0;

   do {
      if ((*dest = *src) == '\\') {
         escape = true;
      } else {
         if (!escape) {
            if (space == NULL && isspace(*src)) {
               space = dest;
            }
         }
         escape = false;
         ++dest;
      }
      ++n;
      ++src;

   } while (!(n == size || ((*src == stop) && !escape) || *src == '\0'));
   *end = src;

   if (space) {
      *space = '\0';
   } else {
      if (n == size) {
         --dest;
         ret = -1;
      }
      *dest = '\0';
   }

   return ret;
}


int parse_config(const char *str, struct config_item *items, FILE *error) {
   int ret = 0;
   const char *ptr = str;

   while (*ptr != '\0') {
      while (isspace(*ptr)) {
         ++ptr;
      }
      if (*ptr == '\0') {
         /* end of parameters */
         return 0;
      }
      
      const char *end;
      char key[80];
      if (trim_copy(key, sizeof(key), ptr, &end, '=') == -1) {
         fprintf(error, "ERROR: Invalid key, starting at: <%s>\n", ptr);
         return -1;
      }

      ptr = end + 1;
      char value[80];
      if (trim_copy(value, sizeof(value), ptr, &end, ';') == -1) {
         fprintf(error, "ERROR: Invalid value, starting at: <%s>\n", ptr);
         return -1;
      }
      if (*end == ';') {
         ptr = end + 1;
      } else {
         ptr = end;
      }

      printf("found: <%s><%s>\n", key, value);

      int ii = 0;
      while (items[ii].key != NULL) {
         if (strcmp(key, items[ii].key) == 0) {
            if (items[ii].found) {
               fprintf(error, "WARNING: Found duplicate entry for \"%s\"\n", 
                       items[ii].key);
            }
            items[ii].found = true;
            
            switch (items[ii].datatype) {
            case DT_SIZE:
               {
                  uint64_t val;
                  if (safe_strtoull(value, &val)) {
                     *items[ii].value.dt_size = (size_t)val;
                  } else {
                     ret = -1;
                  }
               }
               break;
            case DT_FLOAT:
               {
                  float val;
                  if (safe_strtof(value, &val)) {
                     *items[ii].value.dt_float = val;
                  } else {
                     ret = -1;
                  }
               }
               
            case DT_BOOL:
               if (strcasecmp(value, "true") == 0 || strcasecmp(value, "on") == 0) {
                  *items[ii].value.dt_bool = true;
               } else if (strcasecmp(value, "false") == 0 || strcasecmp(value, "off") == 0) {
                  *items[ii].value.dt_bool = false;
               } else {
                  ret = -1;
               }
               break;
            case DT_CONFIGFILE:
               {
                  int r = read_config_file(value, items, error);
                  if (r != 0) {
                     ret = r;
                  } 
               }
            default:
               /* You need to fix your code!!! */
               abort();
            }
            break;
         }
         
         if (ret == -1) {
            fprintf(error, "Invalid entry, Key: <%s> Value: <%s>\n",
                    key, value);
            return ret;
         }
         ++ii;
      }
      
      if (items[ii].key == NULL) {
         fprintf(error, "Unsupported key: <%s>\n", key);
         ret = 1;
      }
   }
   return ret;
}

static int read_config_file(const char *fname, struct config_item items[],
                            FILE *error) {
   FILE *fp = fopen(fname, "r");
   if (fp == NULL) {
      (void)fprintf(error, "Failed to open file: %s\n", fname);
      return -1;
   }
   
   int ret = 0;
   char line[1024];
   while (fgets(line, sizeof(line), fp) != NULL && ret != -1L) {
      if (line[0] == '#') {
         /* Ignore comment line */
         continue;
      }
      
      int r = parse_config(line, items, error);
      if (r != 0) {
         ret = r;
      }
   }
   
   (void)fclose(fp);
   
   return ret;
}
