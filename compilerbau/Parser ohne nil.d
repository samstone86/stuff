import Nullable : Nullable;
import Token : Token;
import Stack : Stack;
import Lexer : Lexer;
import Line : Line;

// just for debugging
import std.stdio : writeln;


import std.string : leftJustify;

// exceptions?
import std.conv : to;

class Parser
{
   class Arc
   {
      enum EnumType
      {
         TOKEN,
         OPERATION,  // TODO< is actualy symbol? >
         ARC,        // another arc, info is the index of the start
         KEYWORD,    // Info is the id of the Keyword

         END,        // Arc end

         ERROR       // not used Arc
      }

      public EnumType Type;

      public void delegate() Callback;
      public Nullable!uint Next;
      public Nullable!uint Alternative;

      public uint Info; // Token Type, Operation Type and so on

      this(EnumType Type, uint Info, void delegate() Callback, Nullable!uint Next, Nullable!uint Alternative)
      {
         this.Type        = Type;
         this.Info        = Info;
         this.Callback    = Callback;
         this.Next        = Next;
         this.Alternative = Alternative;
      }
   }

   this()
   {
      this.fill();

      this.Lines ~= new Line();
   }

   // returns false on fail and true on success
   bool fill()
   {
      void nothing()
      {

      }

      Nullable!uint NullUint = new Nullable!uint(true, 0);

      // programm
      /*   0 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      ,  2                                        , &nothing, new Nullable!uint(false,   1), NullUint                     );
      /*   1 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.POINT       , &nothing, new Nullable!uint(false,  90), NullUint                     );

      // block
      /*   2 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.CONST         , &nothing, new Nullable!uint(false,   3), new Nullable!uint(false,   8));
      /*   3 */this.Arcs ~= new Arc(Parser.Arc.EnumType.TOKEN    , cast(uint)Token.EnumType.IDENTIFIER       , &nothing, new Nullable!uint(false,   4), NullUint                     );
      /*   4 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.EQUAL       , &nothing, new Nullable!uint(false,   5), NullUint                     );
      /*   5 */this.Arcs ~= new Arc(Parser.Arc.EnumType.TOKEN    , cast(uint)Token.EnumType.NUMBER           , &nothing, new Nullable!uint(false,   6), NullUint                     );
      /*   6 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.COMMA       , &nothing, new Nullable!uint(false,   3), new Nullable!uint(false,   7));
      /*   7 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.SEMICOLON   , &nothing, new Nullable!uint(false,   8), NullUint                     );

      /*   8 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.VAR           , &nothing, new Nullable!uint(false,   9), new Nullable!uint(false,  12));
      /*   9 */this.Arcs ~= new Arc(Parser.Arc.EnumType.TOKEN    , cast(uint)Token.EnumType.IDENTIFIER       , &nothing, new Nullable!uint(false,  10), NullUint                     );
      /*  10 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.COMMA       , &nothing, new Nullable!uint(false,   9), new Nullable!uint(false,  11));
      /*  11 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.SEMICOLON   , &nothing, new Nullable!uint(false,  12), NullUint                     );

      /*  12 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.PROCEDURE     , &nothing, new Nullable!uint(false,  13), new Nullable!uint(false,  17));
      /*  13 */this.Arcs ~= new Arc(Parser.Arc.EnumType.TOKEN    , cast(uint)Token.EnumType.IDENTIFIER       , &nothing, new Nullable!uint(false,  14), NullUint                     );
      /*  14 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.SEMICOLON   , &nothing, new Nullable!uint(false,  15), NullUint                     );
      /*  15 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 2                                         , &nothing, new Nullable!uint(false,  16), new Nullable!uint(false,  17));
      /*  16 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.SEMICOLON   , &nothing, new Nullable!uint(false,  12), NullUint                     );
      /*  17 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 20 /* statement */                        , &nothing, new Nullable!uint(false,  18), NullUint                     );
      /*  18 */this.Arcs ~= new Arc(Parser.Arc.EnumType.END      , 0                                         , &nothing, NullUint                     , NullUint                     );

      /*  19 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );

      // statement
      /*  20 */this.Arcs ~= new Arc(Parser.Arc.EnumType.TOKEN    , cast(uint)Token.EnumType.IDENTIFIER       , &nothing, new Nullable!uint(false,  21), new Nullable!uint(false,  24));
      /*  21 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.ASSIGNMENT  , &nothing, new Nullable!uint(false,  22), NullUint                     );
      /*  22 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 50 /* expression */                       , &nothing, new Nullable!uint(false,  23), NullUint                     );
      /*  23 */this.Arcs ~= new Arc(Parser.Arc.EnumType.END      , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  24 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.IF            , &nothing, new Nullable!uint(false,  25), new Nullable!uint(false,  28));
      /*  25 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 80 /* condition */                        , &nothing, new Nullable!uint(false,  26), NullUint                     );
      /*  26 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.THEN          , &nothing, new Nullable!uint(false,  27), NullUint                     );
      /*  27 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 20 /* statement */                        , &nothing, new Nullable!uint(false,  23), NullUint                     );
      /*  28 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.WHILE         , &nothing, new Nullable!uint(false,  29), new Nullable!uint(false,  32));
      /*  29 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 80 /* condition */                        , &nothing, new Nullable!uint(false,  30), NullUint                     );
      /*  30 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.DO            , &nothing, new Nullable!uint(false,  31), NullUint                     );
      /*  31 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 20 /* statement */                        , &nothing, new Nullable!uint(false,  23), NullUint                     );
      /*  32 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.BEGIN         , &nothing, new Nullable!uint(false,  33), new Nullable!uint(false,  36));
      /*  33 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 20 /* statement */                        , &nothing, new Nullable!uint(false,  34), NullUint                     ); //new Nullable!uint(false,  35));
      /*  34 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.SEMICOLON   , &nothing, new Nullable!uint(false,  33), new Nullable!uint(false,  35));//NullUint                     );
      /*  35 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.END           , &nothing, new Nullable!uint(false,  23), NullUint                     );
      /*  36 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.CALL          , &nothing, new Nullable!uint(false,  37), new Nullable!uint(false,  38));
      /*  37 */this.Arcs ~= new Arc(Parser.Arc.EnumType.TOKEN    , cast(uint)Token.EnumType.IDENTIFIER       , &nothing, new Nullable!uint(false,  23), NullUint                     );
      /*  38 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.INPUT       , &nothing, new Nullable!uint(false,  39), new Nullable!uint(false,  40));
      /*  39 */this.Arcs ~= new Arc(Parser.Arc.EnumType.TOKEN    , cast(uint)Token.EnumType.IDENTIFIER       , &nothing, new Nullable!uint(false,  23), NullUint                     );
      /*  40 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.OUTPUT      , &nothing, new Nullable!uint(false,  41), new Nullable!uint(false,  23));
      /*  41 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 50 /* expression */                       , &nothing, new Nullable!uint(false,  23), NullUint                     );

      /*  42 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  43 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  44 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  45 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  46 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  47 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  48 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  49 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      
      // Expression
      /*  50 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.MINUS       , &nothing, new Nullable!uint(false,  51), new Nullable!uint(false,  51));
      /*  51 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 60 /* term */                             , &nothing, new Nullable!uint(false,  52), NullUint                     );
      /*  52 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.PLUS        , &nothing, new Nullable!uint(false,  54), new Nullable!uint(false,  53));
      /*  53 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.MINUS       , &nothing, new Nullable!uint(false,  55), new Nullable!uint(false,  56));
      /*  54 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 60 /* term */                             , &nothing, new Nullable!uint(false,  52), NullUint                     );
      /*  55 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 60 /* term */                             , &nothing, new Nullable!uint(false,  52), NullUint                     );
      /*  56 */this.Arcs ~= new Arc(Parser.Arc.EnumType.END      , 0                                         , &nothing, NullUint                     , NullUint                     );

      /*  57 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  58 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  59 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );

      // Term
      /*  60 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 70 /* factor */                           , &nothing, new Nullable!uint(false,  61), NullUint                     );
      /*  61 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.MUL         , &nothing, new Nullable!uint(false,  62), new Nullable!uint(false,  63));
      /*  62 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 70 /* factor */                           , &nothing, new Nullable!uint(false,  61), NullUint                     );
      /*  63 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.DIV         , &nothing, new Nullable!uint(false,  64), new Nullable!uint(false,  65));
      /*  64 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 70 /* factor */                           , &nothing, new Nullable!uint(false,  61), NullUint                     );
      /*  65 */this.Arcs ~= new Arc(Parser.Arc.EnumType.END      , 0                                         , &nothing, NullUint                     , NullUint                     );

      /*  66 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  67 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  68 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  69 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      
      // factor
      /*  70 */this.Arcs ~= new Arc(Parser.Arc.EnumType.TOKEN    , cast(uint)Token.EnumType.NUMBER           , &nothing, new Nullable!uint(false,  75), new Nullable!uint(false,  71));
      /*  71 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.BRACEOPEN   , &nothing, new Nullable!uint(false,  72), new Nullable!uint(false,  74));
      /*  72 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 50 /* expression */                       , &nothing, new Nullable!uint(false,  73), NullUint                     );
      /*  73 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.BRACECLOSE  , &nothing, new Nullable!uint(false,  75), NullUint                     );
      /*  74 */this.Arcs ~= new Arc(Parser.Arc.EnumType.TOKEN    , cast(uint)Token.EnumType.IDENTIFIER       , &nothing, new Nullable!uint(false,  75), NullUint                     );
      /*  75 */this.Arcs ~= new Arc(Parser.Arc.EnumType.END      , 0                                         , &nothing, NullUint                     , NullUint                     );

      /*  76 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  77 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  78 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      /*  79 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ERROR    , 0                                         , &nothing, NullUint                     , NullUint                     );
      
      // condition
      /*  80 */this.Arcs ~= new Arc(Parser.Arc.EnumType.KEYWORD  , cast(uint)Token.EnumKeyword.ODD           , &nothing, new Nullable!uint(false,  81), new Nullable!uint(false,  82));
      /*  81 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 50 /* expression */                       , &nothing, new Nullable!uint(false,  90), NullUint                     );
      /*  82 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 50 /* expression */                       , &nothing, new Nullable!uint(false,  83), NullUint                     );
      /*  83 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.EQUAL       , &nothing, new Nullable!uint(false,  84), new Nullable!uint(false,  85));
      /*  84 */this.Arcs ~= new Arc(Parser.Arc.EnumType.ARC      , 50 /* expression */                       , &nothing, new Nullable!uint(false,  90), NullUint                     );
      /*  85 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.UNEQUAL     , &nothing, new Nullable!uint(false,  84), new Nullable!uint(false,  86));
      /*  86 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.SMALLER     , &nothing, new Nullable!uint(false,  84), new Nullable!uint(false,  87));
      /*  87 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.SMALLEREQUAL, &nothing, new Nullable!uint(false,  84), new Nullable!uint(false,  88));
      /*  88 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.GREATER     , &nothing, new Nullable!uint(false,  84), new Nullable!uint(false,  89));
      /*  89 */this.Arcs ~= new Arc(Parser.Arc.EnumType.OPERATION, cast(uint)Token.EnumOperation.GREATEREQUAL, &nothing, new Nullable!uint(false,  84), NullUint                     );

      // continue of programm
      /*  90 */this.Arcs ~= new Arc(Parser.Arc.EnumType.END      , 0                                         , &nothing, NullUint                     , NullUint                     );

      if( this.Arcs.length != 91 )
      {
         return false;
      }

      return true;
   }

   public bool parse(ref string ErrorMessage)
   {
      Stack!uint IndexStack;
      bool Success;
      uint CurrentIndex;
      Arc CurrentArc;
      
      Token CurrentToken;
      bool CalleeSuccess;

      IndexStack = new Stack!uint();
      CurrentToken = new Token();

      // set the start index
      IndexStack.push(0);

      // read first token
      this.eatToken(CurrentToken, CalleeSuccess);
      if( !CalleeSuccess )
      {
         ErrorMessage = "Internal Error!\n";
         return false;
      }

      for(;;)
      {
         IndexStack.getTop(CurrentIndex, Success);
         if( !Success )
         {
            // Internal Error
            ErrorMessage = "Internal Error!";
            return false;
         }

         // writeln("CurrentIndex: ", CurrentIndex);

         if( CurrentIndex == 32 )
         {
            int x = 0;
         }

         CurrentArc = this.Arcs[CurrentIndex];

         if( CurrentArc.Type == Parser.Arc.EnumType.ARC )
         {
            if( CurrentArc.Next.isNull() )
            {
               // Internal Error
               ErrorMessage = "Internal Error!";
               return false;
            }

            IndexStack.setTop(CurrentArc.Next.Value, Success);
            if( !Success )
            {
               // Internal Error
               ErrorMessage = "Internal Error!";
               return false;
            }

            IndexStack.push(CurrentArc.Info);

            continue;
         }
         else if( CurrentArc.Type == Parser.Arc.EnumType.OPERATION )
         {
            // check for internal error token
            if( CurrentToken.Type == Token.EnumType.INTERNALERROR )
            {
               ErrorMessage = "Internal Error!";
               return false;
            }

            // check if it matches
            if( (CurrentToken.Type == Token.EnumType.OPERATION) && (CurrentArc.Info == CurrentToken.ContentOperation) )
            {
               // if so, we eat another token and we flush the expected stuff and we continue

               this.eatToken(CurrentToken, CalleeSuccess);
               if( !CalleeSuccess )
               {
                  ErrorMessage = "Internal Error!\n";
                  return false;
               }

               /*
               if( CurrentToken.Line != LineCounter )
               {
                  this.LineCounter = CurrentToken.Line;

                  this.TokensOnLine.length = 0;
               }

               this.TokensOnLine ~= CurrentToken;
               */

               if( CurrentArc.Next.isNull() )
               {
                  ErrorMessage = "internal Error!\n";
                  return false;
               }

               IndexStack.setTop(CurrentArc.Next.Value, Success);
               if( !Success )
               {
                  // Internal Error
                  ErrorMessage = "Internal Error!";
                  return false;
               }

               this.ExpectedOperations.length = 0;
               this.ExpectedKeyword.length = 0;
               this.ExpectedTokens.length = 0;

               continue;
            }

            this.ExpectedOperations ~= Token.OperationPlain[CurrentArc.Info];

            if( CurrentArc.Alternative.isNull() )
            {
               // build the error Message
               this.buildErrorMessage(ErrorMessage);

               return false;
            }

            // if we are here there are alternatives

            IndexStack.setTop(CurrentArc.Alternative.Value, Success);
            if( !Success )
            {
               // Internal Error
               ErrorMessage = "Internal Error!";
               return false;
            }

            continue;
         }
         else if( CurrentArc.Type == Parser.Arc.EnumType.TOKEN )
         {
            // check for internal error token
            if( CurrentToken.Type == Token.EnumType.INTERNALERROR )
            {
               ErrorMessage = "Internal Error!";
               return false;
            }

            // check if the Token matches
            if( CurrentToken.Type == CurrentArc.Info )
            {
               // if so, we eat another token and we flush the expected stuff and we continue

               this.eatToken(CurrentToken, CalleeSuccess);
               if( !CalleeSuccess )
               {
                  ErrorMessage = "Internal Error!\n";
                  return false;
               }

               /*
               if( CurrentToken.Line != LineCounter )
               {
                  this.LineCounter = CurrentToken.Line;

                  this.TokensOnLine.length = 0;
               }

               this.TokensOnLine ~= CurrentToken;
               */

               if( CurrentArc.Next.isNull() )
               {
                  ErrorMessage = "internal Error!\n";
                  return false;
               }

               IndexStack.setTop(CurrentArc.Next.Value, Success);
               if( !Success )
               {
                  // Internal Error
                  ErrorMessage = "Internal Error!";
                  return false;
               }

               this.ExpectedOperations.length = 0;
               this.ExpectedKeyword.length = 0;
               this.ExpectedTokens.length = 0;

               continue;
            }

            ExpectedTokens ~= Token.TypeStrings[CurrentArc.Info];

            if( CurrentArc.Alternative.isNull() )
            {
               // build the error Message
               this.buildErrorMessage(ErrorMessage);

               return false;
            }

            // if we are here there are alternatives

            IndexStack.setTop(CurrentArc.Alternative.Value, Success);
            if( !Success )
            {
               // Internal Error
               ErrorMessage = "Internal Error!";
               return false;
            }

            continue;
         }

         else if( CurrentArc.Type == Parser.Arc.EnumType.KEYWORD )
         {
            // check for internal error token
            if( CurrentToken.Type == Token.EnumType.INTERNALERROR )
            {
               ErrorMessage = "Internal Error!";
               return false;
            }

            // check if the Keyword matches
            if( (CurrentToken.Type == Token.EnumType.KEYWORD) && (CurrentToken.ContentKeyword == CurrentArc.Info) )
            {
               // if so, we eat another token and we flush the expected stuff and we continue

               this.eatToken(CurrentToken, CalleeSuccess);
               if( !CalleeSuccess )
               {
                  ErrorMessage = "Internal Error!\n";
                  return false;
               }

               /*
               if( CurrentToken.Line != LineCounter )
               {
                  this.LineCounter = CurrentToken.Line;

                  this.TokensOnLine.length = 0;
               }

               this.TokensOnLine ~= CurrentToken;
               */

               if( CurrentArc.Next.isNull() )
               {
                  ErrorMessage = "internal Error!\n";
                  return false;
               }

               IndexStack.setTop(CurrentArc.Next.Value, Success);
               if( !Success )
               {
                  // Internal Error
                  ErrorMessage = "Internal Error!";
                  return false;
               }

               this.ExpectedOperations.length = 0;
               this.ExpectedKeyword.length = 0;
               this.ExpectedTokens.length = 0;

               continue;
            }

            this.ExpectedKeyword ~= Token.KeywordString[CurrentArc.Info];

            if( CurrentArc.Alternative.isNull() )
            {
               // build the error Message
               this.buildErrorMessage(ErrorMessage);

               return false;
            }

            // if we are here there are alternatives

            IndexStack.setTop(CurrentArc.Alternative.Value, Success);
            if( !Success )
            {
               // Internal Error
               ErrorMessage = "Internal Error!";
               return false;
            }

            continue;
         }
         else if( CurrentArc.Type == Parser.Arc.EnumType.END )
         {
            uint Value;

            if( IndexStack.getCount() == 1)
            {
               break;
            }

            IndexStack.pop(Value, Success);
            if( !Success )
            {
               // Internal Error
               ErrorMessage = "Internal Error!";
               return false;
            }
         }

         else
         {
            ErrorMessage = "Internal Error!";
            return false;
         }
         
      }

      // check if the last token was an EOF
      if( CurrentToken.Type != Token.EnumType.EOF )
      {
         // TODO< add line information and marker >

         ErrorMessage = "Unexpected Tokens after . Token";
         return false;
      }

      return true;
   }

   // this gets the remaining tokens on the current line
   private bool getRemainingTokensOnLine()
   {
      Lexer.EnumLexerCode LexerReturnValue;
      Token CurrentToken;

      CurrentToken = new Token();

      for(;;)
      {
         uint TokensLength;

         LexerReturnValue = this.LexerObject.getNextToken(CurrentToken);

         if( LexerReturnValue == Lexer.EnumLexerCode.OK )
         {
         }
         else if( LexerReturnValue == Lexer.EnumLexerCode.INTERNALERROR )
         {
            // Internal Lexer error
            // TODO< emit return Value >
            return false;
         }
         else
         {
            // Internal error
            // TODO< emit error message >
            return false;
         }


         // check for EOF token
         if( CurrentToken.Type == Token.EnumType.EOF )
         {
            return true;
         }

         // check for INTERNALERROR Token
         if( CurrentToken.Type == Token.EnumType.INTERNALERROR )
         {
            return false;
         }

         TokensLength = this.Lines[this.Lines.length-1].Tokens.length;
         if( CurrentToken.Line != this.Lines[this.Lines.length-1].Tokens[TokensLength-1].Line ) // Correct?
         {
            return true;
         }
      }

      // NOTE< never reached >
      return true;
   }

   // this reads all tokens in TokensOnLine and reconstructs the text of that line
   // it also marks the token with the MarkerOffset
   private string buildTextWithMarker(uint MarkerOffset)
   {
      string Return;
      string LineContent;
      uint MarkerSpaceCount = 0;

      // TODO
      // TODO< exceptions >
      Return = "Line " ~ to!string(this.CurrentLineNumber) ~ ":" ~ "\n";

      foreach( Token CurrentToken; this.Lines[this.Lines.length-1].Tokens )
      {
         LineContent = leftJustify(LineContent, CurrentToken.Column);
         MarkerSpaceCount = LineContent.length;

         LineContent ~= CurrentToken.getRealString();
      }

      Return ~= LineContent ~ "\n";
      Return ~= leftJustify("", MarkerSpaceCount) ~ "^" ~ "\n";

      return Return;
   }

   private void eatToken(ref Token OutputToken, ref bool Success)
   {
      Lexer.EnumLexerCode LexerReturnValue;
      Token TempToken = new Token();

      LexerReturnValue = this.LexerObject.getNextToken(OutputToken);

      Success = (LexerReturnValue == Lexer.EnumLexerCode.OK);

      this.addTokenToLines(OutputToken.copy());

      //writeln("Parser::eatToken called, returned:");
      //OutputToken.debugIt();

      return;
   }

   private void buildErrorMessage(ref string ErrorMessage)
   {
      string enumerateStrings(string []Strings)
      {
         string Return = "";

         for(;;)
         {
            if( Strings.length == 0 )
            {
               return Return;
            }
            else if( Strings.length == 2 )
            {
               Return ~= Strings[0] ~ " or " ~ Strings[1];
               return Return;
            }
            else
            {
               Return ~= Strings[Strings.length-1] ~ ", ";
               Strings.length--;
            }
         }
      }

      uint CurrentTokenIndex;
      bool CalleeSuccess;

      CurrentTokenIndex = this.Lines[this.Lines.length-1].Tokens.length-1;

      CalleeSuccess = this.getRemainingTokensOnLine();

      if( !CalleeSuccess )
      {
         ErrorMessage = "Internal Error!";
         return;
      }

      ErrorMessage  = this.buildTextWithMarker(CurrentTokenIndex);
               
      if( this.ExpectedKeyword.length == 1 )
      {
         ErrorMessage ~= "Keyword ";
      }
      else if( this.ExpectedKeyword.length > 1 )
      {
         ErrorMessage ~= "Keywords ";
      }

      if( this.ExpectedKeyword.length > 0 )
      {
         ErrorMessage ~= enumerateStrings(this.ExpectedKeyword) ~ " expected!\n";
      }


      if( this.ExpectedOperations.length == 1 )
      {
         ErrorMessage ~= "Operation ";
      }
      else if( this.ExpectedOperations.length > 1 )
      {
         ErrorMessage ~= "Operations ";
      }

      if( this.ExpectedOperations.length > 0 )
      {
         ErrorMessage ~= enumerateStrings(this.ExpectedOperations) ~ " expected!\n";
      }


      if( this.ExpectedTokens.length == 1 )
      {
         ErrorMessage ~= "Token ";
      }
      else if( this.ExpectedTokens.length > 1 )
      {
         ErrorMessage ~= "Tokens ";
      }
      if( this.ExpectedTokens.length > 0 )
      {
         ErrorMessage ~= enumerateStrings(this.ExpectedTokens) ~ " expected!\n";
      }
   }

   public void setLexer(ref Lexer LexerObject0)
   {
      this.LexerObject = LexerObject0;
   }

   public void addTokenToLines(Token TokenObject)
   {
      if( TokenObject.Line != this.CurrentLineNumber )
      {
         CurrentLineNumber = TokenObject.Line;
         this.Lines ~= new Line();
      }

      this.Lines[this.Lines.length-1].Tokens ~= TokenObject;
   }

   private Arc []Arcs;
   public  Lexer LexerObject;

   //private Token []TokensOnLine;


   //private uint LineCounter = 0;

   // this is used for error messages
   private string []ExpectedOperations;
   private string []ExpectedKeyword;
   private string []ExpectedTokens;

   private Line []Lines;
   private uint CurrentLineNumber = 0;
}
