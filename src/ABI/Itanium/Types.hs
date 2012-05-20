{-# LANGUAGE DeriveDataTypeable #-}
module ABI.Itanium.Types (
  DecodedName(..),
  CVQualifier(..),
  CXXType(..),
  Name(..),
  Prefix(..),
  UnqualifiedName(..),
  CtorDtor(..),
  Operator(..),
  Expression(..),
  CallOffset(..),
  Substitution(..)
  ) where

import Data.Data

data DecodedName = Function Name [CXXType]
                 | Data Name
                 | VirtualTable CXXType
                 | VTTStructure CXXType
                 | TypeInfo CXXType
                 | TypeInfoName CXXType
                 | GuardVariable Name
                 | OverrideThunk CallOffset DecodedName
                 | OverrideThunkCovariant CallOffset CallOffset DecodedName
                 deriving (Eq, Show, Data, Typeable)

data CallOffset = VirtualOffset Int Int
                | NonVirtualOffset Int
                deriving (Eq, Show, Data, Typeable)

data CVQualifier = Restrict
                 | Volatile
                 | Const
                 deriving (Eq, Show, Data, Typeable)

data Substitution = Substitution (Maybe String)
                  | SubStdNamespace
                  | SubStdAllocator
                  | SubBasicString
                  | SubBasicStringArgs
                  | SubBasicIstream
                  | SubBasicOstream
                  | SubBasicIostream
                  deriving (Eq, Show, Data, Typeable)

data CXXType = QualifiedType [CVQualifier] CXXType
             | PointerToType CXXType
             | ReferenceToType CXXType
             | RValueReferenceToType CXXType
             | ComplexPairType CXXType
             | ImaginaryType CXXType
             | ParameterPack CXXType
             -- | DeclTypeExpression <expression>
             -- | DeclTypeOther <expression>
             | VendorTypeQualifier String CXXType
             | VoidType
             | Wchar_tType
             | BoolType
             | CharType
             | SignedCharType
             | UnsignedCharType
             | ShortType
             | UnsignedShortType
             | IntType
             | UnsignedIntType
             | LongType
             | UnsignedLongType
             | LongLongType
             | UnsignedLongLongType
             | Int128Type
             | UnsignedInt128Type
             | FloatType
             | DoubleType
             | LongDoubleType
             | Float128Type
             | EllipsisType
               -- There are also four IEEE 754r types and I don't know what that is
             | Char32Type
             | Char16Type
             | AutoType
             | NullPtrType
             | VendorBuiltinType String
             | FunctionType [CXXType]
             | ExternCFunctionType [CXXType]
             | ArrayTypeN (Maybe Int) CXXType
               -- ^ int[5], normal array parameters.  The dimension is
               -- elided for C99 VLAs
             | ArrayTypeE Expression
               -- ^ int[I + 1], expresions due to templates.  The
               -- dimension is not optional here; if it was it would
               -- just be an ArrayTypeN
             | PtrToMemberType CXXType CXXType
               -- ^ Class type, member type
             | ClassEnumType Name
             | SubstitutionType Substitution
             deriving (Eq, Show, Data, Typeable)

data Expression = Expression
                deriving (Eq, Show, Data, Typeable)

data Name = NestedName [CVQualifier] [Prefix] UnqualifiedName
--          | NestedTemplateName [CVQualifier] TemplatePrefix TemplateArgs
          | UnscopedName UnqualifiedName
          | UnscopedStdName UnqualifiedName
            -- Still need unscoped-template-name and local-name
          deriving (Eq, Show, Data, Typeable)

{-
<prefix> ::= <prefix> <unqualified-name>
	     ::= <template-prefix> <template-args>
             ::= <template-param>
             ::= <decltype>
	     ::= # empty
	     ::= <substitution>
             ::= <prefix> <data-member-prefix>

<data-member-prefix> := <member source-name> M

This is currently massively incomplete
-}
data Prefix = DataMemberPrefix String
            | UnqualifiedPrefix UnqualifiedName
            | SubstitutionPrefix Substitution
            deriving (Eq, Show, Data, Typeable)

-- data TemplatePrefix = TemplatePrefix deriving (Eq, Show)
-- data TemplateArgs = TemplateArgs deriving (Eq, Show)

data UnqualifiedName = OperatorName Operator
                     | CtorDtorName CtorDtor
                     | SourceName String
                     -- | UnnamedTypeName String
                     deriving (Eq, Show, Data, Typeable)

data CtorDtor = C1 -- Complete object constructor
              | C2 -- Base object constructor
              | C3 -- Complete object allocating constructor
              | D0 -- Deleting destructor
              | D1 -- Complete object destructor
              | D2 -- Base object destructor
              deriving (Eq, Show, Data, Typeable)

data Operator = OpNew -- new
              | OpNewArray -- new[]
              | OpDelete -- delete
              | OpDeleteArray -- delete[]
              | OpUPlus -- + (unary)
              | OpUMinus -- - (unary)
              | OpAddressOf -- & (unary)
              | OpDeref -- * (unary)
              | OpBitNot -- ~
              | OpPlus -- +
              | OpMinus -- -
              | OpMul -- *
              | OpDiv -- /
              | OpMod -- %
              | OpBitAnd -- &
              | OpBitOr -- \|
              | OpBitXor -- \^
              | OpAssign -- =
              | OpPlusAssign
              | OpMinusAssign
              | OpMulAssign
              | OpDivAssign
              | OpModAssign
              | OpAndAssign
              | OpOrAssign
              | OpXorAssign
              | OpShl
              | OpShr
              | OpShlAssign
              | OpShrAssign
              | OpEquals
              | OpNotEquals
              | OpLt
              | OpGt
              | OpLte
              | OpGte
              | OpNot
              | OpAnd
              | OpOr
              | OpPlusPlus
              | OpMinusMinus
              | OpComma
              | OpArrowStar
              | OpArrow
              | OpCall
              | OpIndex
              | OpQuestion -- ? ??
              | OpSizeofType
              | OpSizeofExpr
              | OpAlignofType
              | OpAlignofExpr
              | OpCast CXXType
              | OpVendor Int String
              deriving (Eq, Show, Data, Typeable)
